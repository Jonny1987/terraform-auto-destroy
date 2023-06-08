variable "n_proxies" {
  type        = number
  description = "The number of proxy servers that will be created"
}

variable "bastion_ami" {
  type        = string
  description = "The AMI of the bastion instance"
}

variable "proxy_ami" {
  type        = string
  description = "The AMI of the proxy instance"
}

variable "lb_ami" {
  type        = string
  description = "The AMI of the load balancer instance"
}

variable "region" {
  type        = string
  default     = "ap-northeast-1"
  description = "The AWS region"
}
