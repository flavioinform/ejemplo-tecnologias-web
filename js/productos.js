// Si no hay sesión iniciada, vuelve al login
async function verificarSesion() {
  const { data } = await supabaseClient.auth.getSession();
  if (!data.session) window.location.href = "index.html";
}

async function cargarProductos() {
  const { data, error } = await supabaseClient
    .from("productos")
    .select("*")
    .order("id", { ascending: false });

  if (error) return mostrarMensaje(error.message);

  const filas = document.getElementById("listaProductos");
  filas.innerHTML = "";
  data.forEach(p => {
    const tr = document.createElement("tr");
    // textContent evita inyectar HTML con el nombre
    [p.id, p.nombre, p.precio].forEach(valor => {
      const td = document.createElement("td");
      td.textContent = valor;
      tr.appendChild(td);
    });
    filas.appendChild(tr);
  });
}

document.getElementById("formProducto").addEventListener("submit", async (e) => {
  e.preventDefault();

  const nombre = document.getElementById("nombre").value.trim();
  const precio = document.getElementById("precio").value;

  const { error } = await supabaseClient.from("productos").insert({ nombre, precio });

  if (error) return mostrarMensaje(error.message);

  e.target.reset();
  document.getElementById("mensaje").innerHTML = "";
  cargarProductos();
});

document.getElementById("btnSalir").addEventListener("click", async () => {
  await supabaseClient.auth.signOut();
  window.location.href = "index.html";
});

verificarSesion();
cargarProductos();
