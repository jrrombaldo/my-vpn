region      = "eu-west-1"
aws_profile = "junior"
cidr        = "10.0.0.0/16"

bucket_log   = "my-vpn-logs"
bucket_state = "my-vpn-state"


instance_type = "t2.medium"

# generated with:
#  ssh-keygen -t rsa -b 4096 -C "my-vpn" -f "my-vpn"
keypair_name  = "my-vpn"
keypair_value = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqdLW9YnB0nxMg97T678izzZPDTCv8iz1g+Uu6VCT6YGAtna5T1AckYgujvdM1rlVtXarasjM5nEl/e0D5tmwH1DHRhwLQZi+8Tjg/sGiZWp8tNcKCvnvHt3c2fxAdRsH8l0ZSZwRijydxTplH+Jmjpr71J1eXj01RXlI/ITEEoZRLsgfE9bLjVhSMzLg1jvMdZPOw+UfLT7assRh7hZJavj4zoghtGpq+3N4YnRwc8sZdPg3RoEKY2i4Os2ed2Jy4UriNbs7qZtdKOeWfX37DfEYCiGbPjDEYCiiGlWXwjIOCORAk9jDmbHrV6MvBd7/FhI28ZHqLBneb0dsyCy4ih82VdF3FCli0tvGV9NHB3o5RrHydBnkyspiWz4UhGPY3N5vdiohWBhm1WTkmOCmJNdOD1A2kmvnBG0ztpwTJ7RUlxKn+7MJWnGZ2bKrja+g0Ui/N9UGiopeslWY+ZudHP4hkWRbElMCdHAvN46yxBUZHwr3YMo0KctaJ/vqQQuE7mdiKYAHliw0Rzg+7rmDn3LZ1tpnmfuG6eVMYr6nIw7TygkSdDopLTgF+Z4vuGe5ueybbYqz0fK0B3px3TAYkVrbszEXTRzS9KY97ZiRJOaZCOf07zmy0NOBzXAjtGWv7ens4Iulaew30P0U76v4xkEZuPjne3sX4CbEdvwx+Gw== my-vpn"