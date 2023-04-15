variable "awsprops" {
    type = map(string)
    default = {
      region = "eu-west-1" # You may change to your region ID
      profile = "default" # You may change your chosen IAM profile's name if you have more than one on your local host
      ami = "ami-09dd5f12915cfb387"
      itype = "t2.micro"
      keyname = "leumi-key"
      secgroupname = "leumi-Sec-Group"
  }
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.181.242.0/24"
}
variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.181.242.0/24"
}