const token = sessionStorage.getItem("uniPiperToken");
if (!token) {
  window.location.replace("login.html");
}
