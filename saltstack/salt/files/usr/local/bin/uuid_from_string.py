#!/usr/bin/env python3

# Generate an UUID based on an input string
import sys
from uuid import UUID
from hashlib import md5

input_string = sys.argv[1]
encoded_string = str.encode(input_string)
generated_uuid = UUID(bytes=md5(encoded_string).digest())
print(generated_uuid)
