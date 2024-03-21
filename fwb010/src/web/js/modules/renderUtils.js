//
// common form and table rendering functions
//
function getFormHtml(title, formId, api, mode, data) {
    let fields = getFormFieldsHtml(data);
    let buttons = getFormButtonsHtml(formId, api, data, mode);
    let html = `
        <div class="card">
          <div class="card-header">${title}</div>
          <div class="card-body">
            <form id="${formId}" onsubmit="return false;">
                ${fields}
            </form>
          </div>
          <div class="card-footer">
                ${buttons}
          </div>
        </div>
    `;
    return html;
}

function getFormFieldsHtml(data) {
    let html = "";
    Object.keys(data).map(key => {
        if (key !== "_id") {
            let value = data[key];
            let type = "text";
            if (key === "email" || key === "password")
                type = key;
            html += `
                <div class="form-group">
                    <label for="${key}">${key}</label>
                    <input type="${type}" name="${key}" class="form-control" id="${key}" value="${value}">
                </div>
            `;
        }
    });
    return html;
}

function getFormButtonsHtml(formId, api, data, mode) {
    let id = data["_id"];
    let html = "";
    if (mode === "edit") {
        html += `
            <button class="btn btn-primary btn-sm mt-2" onclick="API.goBack()">Back</button>
            <button class="btn btn-primary btn-sm mt-2" onclick="API.saveDocument('${id}','${formId}','${api}')">Save</button>
            <button class="btn btn-primary btn-sm mt-2" onclick="API.deleteDocument('${id}','${formId}','${api}')">Delete</button>
        `
    }
    else if (mode === "add") {
        html += `
            <button class="btn btn-primary btn-sm mt-2" onclick="API.goBack()">Back</button>
            <button class="btn btn-primary btn-sm mt-2" onclick="API.addDocument('${formId}','${api}')">Save</button>
        `
    }
    else if (mode === "login") {
        html += `
            <button class="btn btn-primary btn-sm mt-2" onclick="API.login('${formId}','${api}')">Login</button>
            <button class="btn btn-primary btn-sm me-1 mt-2 float-end" onclick="API.signup('${formId}')">Sign Up</button>
            <button class="btn btn-primary btn-sm me-1 mt-2 float-end" onclick="API.forgotPassword('${formId}')">Forgot Password?</button>
        `
    }
    else if (mode === "changePassword") {
        html += `
            <button class="btn btn-primary btn-sm mt-2" onclick="API.goBack()">Back</button>
            <button class="btn btn-primary btn-sm mt-2" onclick="API.changePassword('${formId}','${api}')">Update</button>
        `
    }

    return html;
}

function getCardListHtml(title, entity, list) {
    let headers = getTableHeadersHtml(list);
    let rows = getCardRowsHtml(entity, list);
    let html = `
      <div>
        <h4 class="text-center">${title}</h4>
        <button class="btn btn-primary btn-sm mb-2" onclick="API.handleAddClick('${entity}')">Add</button>
        ${rows}
      </div>
    `;
    return html;
}

function getCardRowsHtml(entity, list) {
    let html = "";
    list.map(row => {
        let id = row["_id"];
        let cols = getCardRowColumnsHtml(row);
        html += `
            <div class="card mb-3">
                <div class="card-body">
                    ${cols}
                </div>
                <div class="card-footer">
                    <button class="btn btn-primary btn-sm mb-2" onclick="API.handleRowClick('${id}','${entity}')">Edit / Delete</button>
                </div>
            </div>
        `;
    });
    return html;
}

function getCardRowColumnsHtml(row) {
    let html = "";
    Object.keys(row).map(key => {
        if (key !== "_id") {
            let value = row[key];
            html += `
                <p><span class="text-primary fw-bold">${key}:</span><span class="p-2">${value}</span></p>
            `
        }
    })
    return html;
}

function getTableHtml(title, entity, list) {
    let headers = getTableHeadersHtml(list);
    let rows = getTableRowsHtml(entity, list);
    let html = `
      <div class="table-responsive-sm">
        <h4 class="text-center">${title}</h4>
        <button class="btn btn-primary btn-sm mb-2" onclick="API.handleAddClick('${entity}')">Add</button>
        <table class="table table-sm table-striped table-bordered table-hover">
            <thead class="table-primary">
                <tr>
                    ${headers}
                </tr>
            </thead>
            <tbody>
                ${rows}
            <tbody>
        </table>
      </div>
    `;
    return html;
}

function getTableHeadersHtml(list) {
    let html = "";
    if (list.length === 0)
        return html;

    let row = list[0];
    Object.keys(row).map(key => {
        if (key !== "_id") {
            html += `
                <th>${key}</th>
            `
        }
    })
    return html;
}

function getTableRowsHtml(entity, list) {
    let html = "";
    list.map(row => {
        let id = row["_id"];
        let cols = getTableRowColumnsHtml(row);
        html += `
            <tr onclick="API.handleRowClick('${id}','${entity}')">${cols}</tr>
        `;
    });
    return html;
}

function getTableRowColumnsHtml(row) {
    let html = "";
    Object.keys(row).map(key => {
        if (key !== "_id") {
            let value = row[key];
            html += `
                <td>${value}</td>
            `
        }
    })
    return html;
}

function renderMessage(msg, textClass) {
    document.getElementById("message").innerHTML = `<p class="${textClass}">${msg}</p>`;
}

function setMessage(msg) {
    renderMessage(msg, "text-success");
}

function setError(msg) {
    renderMessage(msg, "text-danger");
}

function goBack() {
    window.history.back();
}

function waitAndGoBack(millis) {
    setTimeout(goBack, millis);
}

function waitAndGo(millis, hash) {
    setTimeout(function() {window.location.hash = hash;}, millis);
}

export {getFormHtml, getTableHtml, getCardListHtml, setError, setMessage, goBack, waitAndGoBack, waitAndGo};