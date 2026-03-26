from datetime import datetime
from enum import Enum

from pydantic import BaseModel, EmailStr, Field


class UserRole(str, Enum):
    customer = "customer"
    provider = "provider"
    admin = "admin"


class BookingStatus(str, Enum):
    pending = "pending"
    accepted = "accepted"
    en_route = "en_route"
    in_progress = "in_progress"
    completed = "completed"
    cancelled = "cancelled"


class UserCreate(BaseModel):
    full_name: str
    email: EmailStr
    phone: str
    password: str = Field(min_length=8)
    preferred_language: str = "ar"


class UserOut(BaseModel):
    id: int
    full_name: str
    email: EmailStr
    phone: str
    role: UserRole
    preferred_language: str

    model_config = {"from_attributes": True}


class LoginInput(BaseModel):
    email: EmailStr
    password: str


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"


class ServiceCategoryOut(BaseModel):
    id: int
    name_ar: str
    name_en: str
    icon: str

    model_config = {"from_attributes": True}


class ServiceOut(BaseModel):
    id: int
    category_id: int
    name_ar: str
    name_en: str
    base_price_kwd: float
    pricing_type: str
    duration_estimate_min: int

    model_config = {"from_attributes": True}


class ProviderOut(BaseModel):
    user_id: int
    full_name: str
    company_name: str
    rating_avg: float
    jobs_completed: int
    coverage_city: str
    verification_status: str
    is_online: bool


class BookingCreate(BaseModel):
    service_id: int
    city: str = "Kuwait City"
    district: str
    address_details: str
    scheduled_at: datetime
    notes: str | None = None


class BookingOut(BaseModel):
    id: int
    customer_id: int
    provider_id: int | None
    service_id: int
    city: str
    district: str
    address_details: str
    scheduled_at: datetime
    status: BookingStatus
    notes: str | None
    price_estimate_kwd: float
    final_price_kwd: float | None
    created_at: datetime

    model_config = {"from_attributes": True}


class BookingStatusUpdate(BaseModel):
    status: BookingStatus
    final_price_kwd: float | None = None
