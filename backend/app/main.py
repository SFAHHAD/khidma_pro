from fastapi import FastAPI
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.database import Base, SessionLocal, engine
from app.models import Service, ServiceCategory
from app.routers import auth, bookings, categories, providers

app = FastAPI(title=settings.app_name, version=settings.app_version, debug=settings.debug)

app.include_router(auth.router)
app.include_router(categories.router)
app.include_router(providers.router)
app.include_router(bookings.router)


@app.get("/health")
def health():
    return {
        "status": "ok",
        "launch_country": settings.launch_country,
        "launch_cities": settings.launch_cities,
    }


@app.get("/ready")
def readiness():
    db = SessionLocal()
    try:
        db.execute(text("SELECT 1"))
        return {"status": "ready", "database": "ok"}
    finally:
        db.close()


def seed_initial_catalog():
    db: Session = Session(bind=engine)
    try:
        if db.query(ServiceCategory).count() > 0:
            return

        ac = ServiceCategory(name_ar="تكييف", name_en="AC", icon="ac_unit")
        plumbing = ServiceCategory(name_ar="سباكة", name_en="Plumbing", icon="plumbing")
        electrical = ServiceCategory(name_ar="كهرباء", name_en="Electrical", icon="bolt")
        db.add_all([ac, plumbing, electrical])
        db.flush()

        db.add_all(
            [
                Service(
                    category_id=ac.id,
                    name_ar="صيانة تكييف",
                    name_en="AC Maintenance",
                    base_price_kwd=12.0,
                    pricing_type="fixed",
                    duration_estimate_min=60,
                ),
                Service(
                    category_id=plumbing.id,
                    name_ar="إصلاح تسرب مياه",
                    name_en="Leak Repair",
                    base_price_kwd=10.0,
                    pricing_type="fixed",
                    duration_estimate_min=45,
                ),
                Service(
                    category_id=electrical.id,
                    name_ar="إصلاح أعطال كهربائية",
                    name_en="Electrical Fault Fix",
                    base_price_kwd=11.0,
                    pricing_type="fixed",
                    duration_estimate_min=50,
                ),
            ]
        )
        db.commit()
    finally:
        db.close()


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    seed_initial_catalog()
