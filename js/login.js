document.getElementById("formLogin").addEventListener("submit", async (e) => {
  e.preventDefault();

  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value;

  const res = await iniciarSesion(email, password);

  if (res.ok) {
    window.location.href = "productos.html";
  } else {
    mostrarMensaje(res.error);
  }
});
