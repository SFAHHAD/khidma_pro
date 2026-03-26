from datetime import datetime, timedelta

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.db.database import Base, get_db
from app.main import app
from app.models import Service, ServiceCategory, User, UserRole
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
