# Upgrade

## From v0.9.x to v1.x

This version adds a more flexible way to define TLS configuration for the
Ingress resource. Users should replace any previous `certificateSecret`
configuration values with an equivalent `tls` block as described below:

```diff
-  certificateSecret: plex.example.com
+  tls:
+  - hosts:
+    - plex.example.com
+    secretName: cert-example-com
```
