resource "kubernetes_config_map" "keycloak-configmap" {
  metadata {
    name      = "keycloak-configmap"
    namespace = var.NAMESPACE
  }
  data = {
    KC_PROXY                 = "edge"
    KC_DB                    = "postgres"
    KC_DB_URL_HOST           = "postgresql.${var.NAMESPACE}.svc.cluster.local"
    KC_DB_URL_DATABASE       = "keycloak"
    KC_DB_SCHEMA             = "public"
    KC_DB_URL_PORT           = "5432"
    PROXY_ADDRESS_FORWARDING = "true"
    KEYCLOAK_LOGLEVEL        = "DEBUG"
    KC_FEATURES              = "token-exchange"
    KC_HOSTNAME_PATH         = "/login"
  }

}
