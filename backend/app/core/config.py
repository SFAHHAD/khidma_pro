from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import model_validator


class Settings(BaseSettings):
    app_name: str = "Khidma Pro API"
    app_version: str = "1.0.0"
    debug: bool = False
    environment: str = "development"

    # Kuwait-first MVP launch configuration
    launch_country: str = "Kuwait"
    launch_cities: list[str] = ["Kuwait City", "Al Ahmadi"]

    database_url: str = "sqlite:///./khidma.db"
    jwt_secret: str = "dev-only-change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    @model_validator(mode="after")
    def validate_security(self):
        if self.environment.lower() == "production" and self.jwt_secret == "dev-only-change-me":
            raise ValueError("jwt_secret must be set via environment in production.")
        return self


settings = Settings()
