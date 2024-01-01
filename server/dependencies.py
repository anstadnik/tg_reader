import logging
import os
import secrets
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials

security = HTTPBasic()

login, password = os.environ["LOGIN"], os.environ["PASSWORD"]


def verify_credentials(credentials: Annotated[HTTPBasicCredentials, Depends(security)]):
    login_valid = secrets.compare_digest(credentials.username, login)
    password_valid = secrets.compare_digest(credentials.password, password)
    logging.info(f"{login_valid=}, {password_valid=}")
    if not (login_valid and password_valid):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Basic"},
        )
