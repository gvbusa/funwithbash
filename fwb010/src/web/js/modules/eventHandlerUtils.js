import {setError, setMessage, goBack, waitAndGoBack} from "./renderUtils.js"

//
// click event handlers
//
function handleRowClick(id, entity) {
    window.location = `#${entity}/${id}`;
}

function handleAddClick(entity) {
    window.location = `#${entity}`;
}

async function addDocument(formId, api) {
    let formData = new FormData(document.querySelector(`#${formId}`));
    let data = Object.fromEntries(formData.entries());
    try {
        let response = await axios.post(api, data, {headers: {"Content-Type": "application/json"}});
        if (! response) return;
        setMessage("Added Successfully");
        waitAndGoBack(2000);
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function saveDocument(id, formId, api) {
    let formData = new FormData(document.querySelector(`#${formId}`));
    let data = Object.fromEntries(formData.entries());
    try {
        let response = await axios.put(`${api}/${id}`, data, {headers: {"Content-Type": "application/json"}});
        if (! response) return;
        setMessage("Updated Successfully");
        waitAndGoBack(2000);
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function deleteDocument(id, formId, api) {
    try {
        let response = await axios.delete(`${api}/${id}`);
        if (! response) return;
        setMessage("Deleted Successfully");
        waitAndGoBack(2000);
    } catch (err) {
        setError(err.response.data.error);
    }
}

export {handleRowClick, handleAddClick, addDocument, saveDocument, deleteDocument};