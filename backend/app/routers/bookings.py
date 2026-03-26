from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.dependencies import get_current_user, require_role
from app.db.database import get_db
from app.models import Booking, BookingStatus, Service, User, UserRole
from app.schemas import BookingCreate, BookingOut, BookingStatusUpdate

router = APIRouter(prefix="/bookings", tags=["bookings"])


@router.post("", response_model=BookingOut, status_code=status.HTTP_201_CREATED)
def create_booking(
    payload: BookingCreate,
    customer: User = Depends(require_role(UserRole.customer)),
    db: Session = Depends(get_db),
):
    service = db.query(Service).filter(Service.id == payload.service_id, Service.is_active.is_(True)).first()
    if service is None:
        raise HTTPException(status_code=404, detail="Service not found")

    if payload.city not in settings.launch_cities:
        raise HTTPException(
            status_code=400,
            detail=f"City not supported for MVP launch. Allowed cities: {', '.join(settings.launch_cities)}",
        )

    scheduled_at = payload.scheduled_at
    if scheduled_at.tzinfo is None:
        scheduled_at = scheduled_at.replace(tzinfo=timezone.utc)
    now_utc = datetime.now(timezone.utc)
    if scheduled_at <= now_utc:
        raise HTTPException(status_code=400, detail="scheduled_at must be in the future")

    booking = Booking(
        customer_id=customer.id,
        service_id=payload.service_id,
        city=payload.city,
        district=payload.district,
        address_details=payload.address_details,
        scheduled_at=scheduled_at,
        notes=payload.notes,
        price_estimate_kwd=service.base_price_kwd,
        status=BookingStatus.pending,
    )
    db.add(booking)
    db.commit()
    db.refresh(booking)
    return booking


@router.get("/me", response_model=list[BookingOut])
def my_bookings(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if user.role == UserRole.customer:
        return db.query(Booking).filter(Booking.customer_id == user.id).order_by(Booking.created_at.desc()).all()
    if user.role == UserRole.provider:
        return db.query(Booking).filter(Booking.provider_id == user.id).order_by(Booking.created_at.desc()).all()
    return db.query(Booking).order_by(Booking.created_at.desc()).all()


@router.get("/available", response_model=list[BookingOut])
def available_bookings(
    provider: User = Depends(require_role(UserRole.provider, UserRole.admin)),
    db: Session = Depends(get_db),
):
    return (
        db.query(Booking)
        .filter(Booking.status == BookingStatus.pending, Booking.provider_id.is_(None))
        .order_by(Booking.created_at.desc())
        .all()
    )


@router.patch("/{booking_id}/status", response_model=BookingOut)
def update_status(
    booking_id: int,
    payload: BookingStatusUpdate,
    provider: User = Depends(require_role(UserRole.provider, UserRole.admin)),
    db: Session = Depends(get_db),
):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if booking is None:
        raise HTTPException(status_code=404, detail="Booking not found")

    if provider.role == UserRole.provider and booking.provider_id not in (None, provider.id):
        raise HTTPException(status_code=403, detail="Booking belongs to another provider")

    if booking.provider_id is None and provider.role == UserRole.provider:
        booking.provider_id = provider.id

    booking.status = payload.status
    if payload.final_price_kwd is not None:
        booking.final_price_kwd = payload.final_price_kwd

    db.add(booking)
    db.commit()
    db.refresh(booking)
    return booking
