
# 'demo-app' folder contains code for the app 

shinylive::export(
  appdir = "demo-app",
  destdir = "docs"
)
beepr::beep()


# run shinylive app locally
httpuv::runStaticServer(
  dir = "docs/",
  port = 8888
)
