async function renderMenu() {
    document.getElementById("nav").innerHTML = getMenuHtml();
}

function getMenuHtml() {
    let userMenuHtml = "";
    if (API.email !== "") {
        userMenuHtml = `
          <ul class="navbar-nav ms-auto">
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">${API.email}</a>
              <div class="dropdown-menu">
                <a class="dropdown-item" href="#changePassword">Change Password</a>
                <a class="dropdown-item" href="#logout">Logout</a>
              </div>
            </li>
          </ul>
        `
    }

    return `
        <nav class="navbar navbar-expand-lg bg-primary" data-bs-theme="dark">
          <div class="container-fluid" >
            <a class="navbar-brand" href="#">TaskManager</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#collapse" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="collapse">
                ${userMenuHtml}
            </div>
          </div>
        </nav>
    `
}

export {renderMenu};