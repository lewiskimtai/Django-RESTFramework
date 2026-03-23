# api/models.py  (or wherever your CustomUser is defined)

from django.contrib.auth.models import AbstractUser, Group, Permission
from django.db import models


class CustomUser(AbstractUser):
    # your extra fields here, e.g.
    # phone = models.CharField(max_length=15, blank=True)
    # ...

    # ────────────────────────────────────────────────
    # IMPORTANT: override these two fields with unique related_name
    # ────────────────────────────────────────────────
    groups = models.ManyToManyField(
        Group,
        related_name="customuser_set",          # ← must be unique, never 'user_set'
        blank=True,
        help_text="The groups this user belongs to. A user will get all permissions granted to each of their groups.",
        related_query_name="customuser",
        verbose_name="groups",
    )

    user_permissions = models.ManyToManyField(
        Permission,
        # ← same related_name is fine here (or make it 'customuser_permissions_set' if you prefer)
        related_name="customuser_set",
        blank=True,
        help_text="Specific permissions for this user.",
        related_query_name="customuser",
        verbose_name="user permissions",
    )

    # If you have a custom manager, define it here too
    # objects = CustomUserManager()

    class Meta:
        verbose_name = "custom user"
        verbose_name_plural = "custom users"
