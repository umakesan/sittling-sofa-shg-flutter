from pydantic import BaseModel


class LoginRequest(BaseModel):
    user_id: str
    password: str


class TokenResponse(BaseModel):
    token: str
    user_id: str
    name: str
    role: str
