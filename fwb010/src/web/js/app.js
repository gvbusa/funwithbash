// imports
import {renderTaskList, renderTaskForm} from "./modules/taskList.js"
import {setMessage, setError, goBack, waitAndGo} from "./modules/renderUtils.js"
import {handleRowClick, handleAddClick, addDocument, saveDocument, deleteDocument} from "./modules/eventHandlerUtils.js"
import {authCheck, login, signup, verifyEmail, forgotPassword, resetPassword, changePassword, logout, renderLoginForm, renderChangePasswordForm} from "./modules/auth.js"
import {renderMenu} from "./modules/menu.js"

// global API
var API = {
    start: start,
    handleRowClick: handleRowClick,
    handleAddClick: handleAddClick,
    addDocument: addDocument,
    saveDocument: saveDocument,
    deleteDocument: deleteDocument,
    goBack: goBack,
    login: login,
    signup: signup,
    forgotPassword: forgotPassword,
    changePassword: changePassword,
    email: ""
}
window.API = API;

//
// router
//
window.onhashchange = route;

//
// global axios error handler for unauthenticated
//
axios.interceptors.response.use(
  response => response,
  error => {
    if (error.response.status === 401) {
      setError(error.response.data.error);
      waitAndGo(3000, "#login");
    } else {
        return Promise.reject(error);
    }
});

async function start() {
    // authCheck
    let hash = window.location.hash;
    if (! await authCheck(hash)) {
        if (! (hash.startsWith("#verifyEmail") || hash.startsWith("#resetPassword"))) {
            window.location.hash="#login";
        }
    }

    // start routing
    route();
}

async function route() {
    let hash = window.location.hash;
    setMessage("");

    await renderMenu();

    let regexTaskEdit = /^#task\/.*$/;
    let regexTaskAdd = /^#task$/;
    let regexLogin = /^#login$/;
    let regexVerifyEmail = /^#verifyEmail\/.*$/;
    let regexResetPassword = /^#resetPassword\/.*$/;
    let regexChangePassword = /^#changePassword$/;
    let regexLogout = /^#logout$/;
    if (regexTaskEdit.test(hash)) {
        await renderTaskForm(hash, "edit");
    }
    else if (regexTaskAdd.test(hash)) {
        await renderTaskForm(hash, "add");
    }
    else if (regexLogin.test(hash)) {
        await renderLoginForm();
    }
    else if (regexVerifyEmail.test(hash)) {
        await verifyEmail(hash);
    }
    else if (regexResetPassword.test(hash)) {
        await resetPassword(hash);
    }
    else if (regexChangePassword.test(hash)) {
        await renderChangePasswordForm(hash);
    }
    else if (regexLogout.test(hash)) {
        await logout();
    }
    else {
        window.location = "#tasklist"
        await renderTaskList();
    }
}

