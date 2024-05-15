import re
from datetime import datetime


def get_coupon_benefit_rule(coupon_type, condition_amount, benefit_amount, condition_num, benefit_discount) -> str:
    if coupon_type == "3201":
        return f"Meet {condition_amount} Abstract {benefit_amount} Yuan"
    if coupon_type == "3202":
        return f"Meet {condition_num} Do {benefit_discount} discount"
    if coupon_type == "3203":
        return f"Abstract {benefit_amount} Yuan"


def get_activity_benefit_rule(activity_type, condition_amount, benefit_amount, condition_num, benefit_discount) -> str:
    if activity_type == "3101":
        return f"Meet {condition_amount} Yuan Abstract {benefit_amount} Yuan"
    if activity_type == "3102":
        return f"Meet {condition_num} Do {benefit_discount} discount"
    if activity_type == "3103":
        return f"Do {benefit_discount} discount"


def encode_name(name: str) -> str:
    if name is None or name == '':
        return ''
    return name[:1] + len(name[1:]) * '*'


def encode_phone_number(phone_number: str) -> str:
    if phone_number is None:
        return ''
    pattern = re.compile(r"^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\\d{8}$")
    if pattern.match(phone_number):
        return phone_number[:3] + 11 * '*'


def encode_email(email: str) -> str:
    if email is None:
        return ''
    pattern = re.compile(r"^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$")
    if pattern.match(email):
        return f"*@{email.split('@')[1]}"


def has_continue_dates(dates, continue_num) -> bool:
    if continue_num < 1:
        raise Exception("Invalid continue number")
    size = len(dates)
    if size < 1 or continue_num > size:
        return False
    if continue_num == 1:
        return True

    dates.sort()
    for i in range(2, size):
        d1 = datetime.strptime(dates[i - 2], "%Y-%m-%d")
        d2 = datetime.strptime(dates[i], "%Y-%m-%d")
        if (d2 - d1).days == continue_num - 1:
            return True

    return False
