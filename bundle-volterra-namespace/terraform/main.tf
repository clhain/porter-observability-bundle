resource "random_id" "this" {
  byte_length = 4
}

# Create the volterra namespace and sleep 10s to prevent creation failures for child objects. 
resource "volterra_namespace" "this" {
  name = var.name != "" ?  var.name : "${var.name_prefix}-${random_id.this.hex}"
  provisioner "local-exec" {
    command = "sleep 10s"
  }
}
