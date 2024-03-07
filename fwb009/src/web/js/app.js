//
// router
//
window.onhashchange = route;

async function route() {
    setMessage("");
    let hash = window.location.hash
    let regexTaskEdit = /^#task\/.*$/
    let regexTaskAdd = /^#task$/
    if (regexTaskEdit.test(hash)) {
        await renderTaskForm(hash, "edit");
    }
    else if (regexTaskAdd.test(hash)) {
        await renderTaskForm(hash, "add");
    }
    else {
        window.location = "#tasklist"
        await renderTaskList();
    }
}

//
// renderers
//

async function renderTaskList() {
    try {
        let response = await axios.get('/api/task');
        document.getElementById("main").innerHTML = getTableHtml("Task List", response.data);
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function renderTaskForm(hash, mode) {
    if (mode === "edit") {
        let id = hash.substring(hash.lastIndexOf("/")+1, hash.length);
        try {
            let response = await axios.get(`/api/task/${id}`);
            document.getElementById("main").innerHTML = getFormHtml("Edit / Delete Task", "taskform", mode, response.data);
        } catch (err) {
            setError(err.response.data.error);
        }
    }
    else {
        document.getElementById("main").innerHTML = getFormHtml("Add Task", "taskform", mode, {name: "", notes: ""});
    }
}

//
// click event handlers
//
function handleRowClick(id) {
    window.location = `#task/${id}`;
}

function handleAddClick() {
    window.location = `#task`;
}

async function addDocument() {
    let formData = new FormData(document.querySelector('#taskform'));
    let data = Object.fromEntries(formData.entries());
    try {
        let response = await axios.post('/api/task', data, {headers: {"Content-Type": "application/json"}});
        setMessage("Added Successfully");
        waitAndGoBack(2000);
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function saveDocument(id) {
    let formData = new FormData(document.querySelector('#taskform'));
    let data = Object.fromEntries(formData.entries());
    try {
        let response = await axios.put(`/api/task/${id}`, data, {headers: {"Content-Type": "application/json"}});
        setMessage("Updated Successfully");
        waitAndGoBack(2000);
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function deleteDocument(id) {
    try {
        let response = await axios.delete(`/api/task/${id}`);
        setMessage("Deleted Successfully");
        waitAndGoBack(2000);
    } catch (err) {
        setError(err.response.data.error);
    }
}


//
// common form and table rendering functions
//
function getFormHtml(title, formId, mode, data) {
    let fields = getFormFieldsHtml(data);
    let buttons = getFormButtonsHtml(data, mode);
    let html = `
        <h4 class="text-center">${title}</h4>
        <form id="${formId}" onsubmit="return false;">
            ${fields}
            ${buttons}
        </form>
    `;
    return html;
}

function getFormFieldsHtml(data) {
    let html = "";
    Object.keys(data).map(key => {
        if (key !== "_id") {
            let value = data[key];
            html += `
                <div class="form-group">
                    <label for="${key}">${key}</label>
                    <input type="text" name="${key}" class="form-control" id="${key}" value="${value}">
                </div>
            `;
        }
    });
    return html;
}

function getFormButtonsHtml(data, mode) {
    let id = data["_id"];
    let html = "";
    if (mode === "edit") {
        html += `
            <button class="btn btn-primary btn-sm mt-2" onclick="goBack()">Back</button>
            <button class="btn btn-primary btn-sm mt-2" onclick="saveDocument('${id}')">Save</button>
            <button class="btn btn-primary btn-sm mt-2" onclick="deleteDocument('${id}')">Delete</button>
        `
    }
    else {
        html += `
            <button class="btn btn-primary btn-sm mt-2" onclick="goBack()">Back</button>
            <button class="btn btn-primary btn-sm mt-2" onclick="addDocument()">Save</button>
        `
    }
    return html;
}

function getTableHtml(title, list) {
    let headers = getTableHeadersHtml(list);
    let rows = getTableRowsHtml(list);
    let html = `
      <div class="table-responsive-sm">
        <h4 class="text-center">${title}</h4>
        <button class="btn btn-primary btn-sm mb-2" onclick="handleAddClick()">Add</button>
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

function getTableRowsHtml(list) {
    let html = "";
    list.map(row => {
        let id = row["_id"];
        let cols = getTableRowColumnsHtml(row);
        html += `
            <tr onclick="handleRowClick('${id}')">${cols}</tr>
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
