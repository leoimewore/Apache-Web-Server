variable "vpc-CIDR" {
    default = "10.0.0.0/16"
  
}

variable "prefix" {
   type = map
   default = {
      sub-1 = {
         az = "use1-az1"
         cidr = "10.0.0.0/24"
      }
      sub-2 = {
         az = "use1-az2"
         cidr = "10.0.2.0/24"
      }
      
   }
}
variable "suffix" {
   type = map
   default = {
      sub-1 = {
         az = "use1-az1"
         cidr = "10.0.1.0/24"
      }
      sub-2 = {
         az = "use1-az2"
         cidr = "10.0.3.0/24"
      }
      
   }
}

# variable "ami" {
#    default = "ami-051f7e7f6c2f40dc1"
  
# }



