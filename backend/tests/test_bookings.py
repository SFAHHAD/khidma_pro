from datetime import datetime, timedelta, timezone

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.db.database import Base, get_db
from app.main import app
from app.models import Booking, BookingStatus, Service, ServiceCategory, User, UserRole
from app.security import hash_password

TEST_DB_URL = "sqlite:///./test_khidma.db"
engine = create_engine(TEST_DB_URL, connect_args={"check_same_thread": False}, future=True)
TestingSessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


def _seed_user_and_service():
    db = TestingSessionLocal()
    try:
        customer = User(
            full_name="Kuwait Test Customer",
            email="customer@test.com",
            phone="+96550000001",
            role=UserRole.customer,
            preferred_language="ar",
            password_hash=hash_password("password123"),
            is_verified=True,
        )
        category = ServiceCategory(name_ar="تكييف", name_en="AC", icon="ac_unit", is_active=True)
        db.add_all([customer, category])
        db.flush()

        service = Service(
            category_id=category.id,
            name_ar="صيانة تكييف",
            name_en="AC Maintenance",
            base_price_kwd=12.0,
            pricing_type="fixed",
            duration_estimate_min=60,
            is_active=True,
        )
        db.add(service)
        db.commit()
        db.refresh(customer)
        db.refresh(service)
        return customer, service
    finally:
        db.close()


def _create_user(
    email: str,
    phone: str,
    role: UserRole,
    full_name: str,
    password: str = "password123",
) -> User:
    db = TestingSessionLocal()
    try:
        user = User(
            full_name=full_name,
            email=email,
            phone=phone,
            role=role,
            preferred_language="ar",
            password_hash=hash_password(password),
            is_verified=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user
    finally:
        db.close()


def _create_booking(customer_id: int, provider_id: int | None, service_id: int) -> Booking:
    db = TestingSessionLocal()
    try:
        booking = Booking(
            customer_id=customer_id,
            provider_id=provider_id,
            service_id=service_id,
            city="Kuwait City",
            district="Salmiya",
            address_details="Block 1",
            scheduled_at=datetime.now(timezone.utc) + timedelta(hours=4),
            status=BookingStatus.pending,
            price_estimate_kwd=12.0,
        )
        db.add(booking)
        db.commit()
        db.refresh(booking)
        return booking
    finally:
        db.close()


@pytest.fixture(autouse=True)
def setup_and_teardown_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


def _login_and_get_token(email: str, password: str) -> str:
    response = client.post("/auth/login", json={"email": email, "password": password})
    assert response.status_code == 200
    return response.json()["access_token"]


def test_register_ignores_role_escalation_and_forces_customer():
    response = client.post(
        "/auth/register",
        json={
            "full_name": "Escalation Attempt",
            "email": "escalate@test.com",
            "phone": "+96550000099",
            "password": "password123",
            "role": "admin",
            "preferred_language": "ar",
        },
    )

    assert response.status_code == 201
    payload = response.json()
    assert payload["role"] == "customer"

    db = TestingSessionLocal()
    try:
        created = db.query(User).filter(User.email == "escalate@test.com").first()
        assert created is not None
        assert created.role == UserRole.customer
    finally:
        db.close()


def test_create_booking_allows_kuwait_city():
    _, service = _seed_user_and_service()
    token = _login_and_get_token("customer@test.com", "password123")

    payload = {
        "service_id": service.id,
        "city": "Kuwait City",
        "district": "Salmiya",
        "address_details": "Block 1, Street 2, House 3",
        "scheduled_at": (datetime.utcnow() + timedelta(hours=4)).isoformat(),
        "notes": "AC is leaking water",
    }
    response = client.post("/bookings", json=payload, headers={"Authorization": f"Bearer {token}"})

    assert response.status_code == 201
    data = response.json()
    assert data["city"] == "Kuwait City"
    assert data["price_estimate_kwd"] == 12.0
    assert data["status"] == "pending"


def test_create_booking_allows_al_ahmadi():
    _, service = _seed_user_and_service()
    token = _login_and_get_token("customer@test.com", "password123")

    payload = {
        "service_id": service.id,
        "city": "Al Ahmadi",
        "district": "Fahaheel",
        "address_details": "Street 10, Building 22",
        "scheduled_at": (datetime.utcnow() + timedelta(hours=6)).isoformat(),
        "notes": "Need urgent repair",
    }
    response = client.post("/bookings", json=payload, headers={"Authorization": f"Bearer {token}"})

    assert response.status_code == 201
    data = response.json()
    assert data["city"] == "Al Ahmadi"
    assert data["status"] == "pending"


def test_create_booking_rejects_unsupported_city():
    _, service = _seed_user_and_service()
    token = _login_and_get_token("customer@test.com", "password123")

    payload = {
        "service_id": service.id,
        "city": "Hawalli",
        "district": "Rumaithiya",
        "address_details": "Avenue 5",
        "scheduled_at": (datetime.utcnow() + timedelta(hours=3)).isoformat(),
    }
    response = client.post("/bookings", json=payload, headers={"Authorization": f"Bearer {token}"})

    assert response.status_code == 400
    assert "City not supported for MVP launch" in response.json()["detail"]


def test_create_booking_rejects_past_scheduled_datetime():
    _, service = _seed_user_and_service()
    token = _login_and_get_token("customer@test.com", "password123")

    payload = {
        "service_id": service.id,
        "city": "Kuwait City",
        "district": "Salmiya",
        "address_details": "Block 3",
        "scheduled_at": (datetime.utcnow() - timedelta(minutes=10)).isoformat(),
    }
    response = client.post("/bookings", json=payload, headers={"Authorization": f"Bearer {token}"})

    assert response.status_code == 400
    assert response.json()["detail"] == "scheduled_at must be in the future"


def test_provider_cannot_update_other_provider_booking():
    customer, service = _seed_user_and_service()
    provider_a = _create_user(
        email="provider-a@test.com",
        phone="+96550000100",
        role=UserRole.provider,
        full_name="Provider A",
    )
    provider_b = _create_user(
        email="provider-b@test.com",
        phone="+96550000101",
        role=UserRole.provider,
        full_name="Provider B",
    )
    booking = _create_booking(customer.id, provider_a.id, service.id)

    provider_b_token = _login_and_get_token("provider-b@test.com", "password123")
    response = client.patch(
        f"/bookings/{booking.id}/status",
        json={"status": "accepted"},
        headers={"Authorization": f"Bearer {provider_b_token}"},
    )

    assert response.status_code == 403
    assert response.json()["detail"] == "Booking belongs to another provider"
