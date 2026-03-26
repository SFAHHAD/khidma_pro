import enum
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Enum, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class UserRole(str, enum.Enum):
    customer = "customer"
    provider = "provider"
    admin = "admin"


class BookingStatus(str, enum.Enum):
    pending = "pending"
    accepted = "accepted"
    en_route = "en_route"
    in_progress = "in_progress"
    completed = "completed"
    cancelled = "cancelled"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    full_name: Mapped[str] = mapped_column(String(120))
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    phone: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), default=UserRole.customer)
    preferred_language: Mapped[str] = mapped_column(String(8), default="ar")
    password_hash: Mapped[str] = mapped_column(String(255))
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    provider_profile = relationship("ProviderProfile", back_populates="user", uselist=False)


class ServiceCategory(Base):
    __tablename__ = "service_categories"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name_ar: Mapped[str] = mapped_column(String(120), unique=True)
    name_en: Mapped[str] = mapped_column(String(120), unique=True)
    icon: Mapped[str] = mapped_column(String(64), default="build")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class Service(Base):
    __tablename__ = "services"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    category_id: Mapped[int] = mapped_column(ForeignKey("service_categories.id"), index=True)
    name_ar: Mapped[str] = mapped_column(String(120))
    name_en: Mapped[str] = mapped_column(String(120))
    base_price_kwd: Mapped[float] = mapped_column(Float)
    pricing_type: Mapped[str] = mapped_column(String(16), default="fixed")
    duration_estimate_min: Mapped[int] = mapped_column(Integer, default=60)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class ProviderProfile(Base):
    __tablename__ = "provider_profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, index=True)
    company_name: Mapped[str] = mapped_column(String(120))
    rating_avg: Mapped[float] = mapped_column(Float, default=0.0)
    jobs_completed: Mapped[int] = mapped_column(Integer, default=0)
    coverage_city: Mapped[str] = mapped_column(String(64), default="Kuwait City")
    verification_status: Mapped[str] = mapped_column(String(24), default="pending")
    is_online: Mapped[bool] = mapped_column(Boolean, default=False)

    user = relationship("User", back_populates="provider_profile")


class Booking(Base):
    __tablename__ = "bookings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    customer_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    provider_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True, index=True)
    service_id: Mapped[int] = mapped_column(ForeignKey("services.id"), index=True)
    city: Mapped[str] = mapped_column(String(64), default="Kuwait City")
    district: Mapped[str] = mapped_column(String(64))
    address_details: Mapped[str] = mapped_column(String(255))
    scheduled_at: Mapped[datetime] = mapped_column(DateTime, index=True)
    status: Mapped[BookingStatus] = mapped_column(Enum(BookingStatus), default=BookingStatus.pending)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    price_estimate_kwd: Mapped[float] = mapped_column(Float)
    final_price_kwd: Mapped[float | None] = mapped_column(Float, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
