variable "cluster_name" {
  type        = string
  description = "The name of AWS ECS cluster"
  default     = "jb_cluster"
}

variable "azs_list" {
  type        = list(string)
  description = "avail zones"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}