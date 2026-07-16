from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="", case_sensitive=False)

    database_url: str = Field(
        default="postgresql://rota:rota_dev_password@localhost:5432/rota",
        validation_alias="DATABASE_URL",
    )
    catalog_cache_seconds: int = Field(default=30, ge=0, le=300)
    model_version: str = "content-based-xai-v1"


settings = Settings()
