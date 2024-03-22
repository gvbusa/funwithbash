import {getFormHtml, getTableHtml, getCardListHtml, setError, setMessage} from "./renderUtils.js"

//
// renderers
//

async function renderTaskList() {
    try {
        let response = await axios.get('/api/task');
        if (! response) return;
        if (document.documentElement.clientWidth < 576)
            document.getElementById("main").innerHTML = getCardListHtml("Task List", "task", response.data);
        else
            document.getElementById("main").innerHTML = getTableHtml("Task List", "task", response.data);
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function renderTaskForm(hash, mode) {
    if (mode === "edit") {
        let id = hash.substring(hash.lastIndexOf("/")+1, hash.length);
        try {
            let response = await axios.get(`/api/task/${id}`);
            if (! response) return;
            document.getElementById("main").innerHTML = getFormHtml("Edit / Delete Task", "taskform", "/api/task", mode, response.data);
        } catch (err) {
            setError(err.response.data.error);
        }
    }
    else {
        document.getElementById("main").innerHTML = getFormHtml("Add Task", "taskform", "/api/task", mode, {name: "", notes: ""});
    }
}


export {renderTaskList, renderTaskForm}