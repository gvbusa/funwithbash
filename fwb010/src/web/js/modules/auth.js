import {getFormHtml, getTableHtml, setError, setMessage, waitAndGo} from "./renderUtils.js"

async function authCheck(hash) {
    if (hash === "#login")
        return true;

    let authToken = getCookie("fwbAuthCookie");
    if (authToken === "") {
        return false;
     }

     try {
        axios.defaults.headers.common['Authorization'] = authToken;
        let response = await axios.get('/api/authValid');
        API.email = response.data.email;
        return true
     } catch (err) {
        document.cookie = `fwbAuthCookie=`;
        return false;
     }
}

async function renderLoginForm() {
    document.getElementById("main").innerHTML = getFormHtml("Login", "loginform", "/api/login", "login", {email: "", password: ""});
}

async function renderChangePasswordForm() {
    document.getElementById("main").innerHTML = getFormHtml("Change Password", "changepasswordform", "/api/changePassword", "changePassword", {password: ""});
}

async function login(formId, api) {
    let formData = new FormData(document.querySelector(`#${formId}`));
    let data = Object.fromEntries(formData.entries());
    try {
        let response = await axios.post(api, data, {headers: {"Content-Type": "application/json"}});
        if (! response) return;
        let email = response.data.email;
        let authToken = response.data.insertedId;
        document.cookie = `fwbAuthCookie=${authToken}`
        axios.defaults.headers.common['Authorization'] = authToken;
        API.email = email;
        window.location.hash = "#";
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function signup(formId) {
    let formData = new FormData(document.querySelector(`#${formId}`));
    let data = Object.fromEntries(formData.entries());
    try {
        let response = await axios.post("/api/signup", data, {headers: {"Content-Type": "application/json"}});
        setMessage("Please check your email inbox for a verification email from us, and click the included link to verify")
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function forgotPassword(formId) {
    let formData = new FormData(document.querySelector(`#${formId}`));
    let data = Object.fromEntries(formData.entries());
    try {
        let response = await axios.post("/api/forgotPassword", data, {headers: {"Content-Type": "application/json"}});
        setMessage("Please check your email inbox for an email from us, and click the included link to reset your password")
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function resetPassword(hash) {
    let id = hash.substring(hash.lastIndexOf("/")+1, hash.length);
    try {
        let response = await axios.get(`/api/resetPassword/${id}`);
        setMessage("We have sent you an email with a temporary password. Please login with it and then immediately change your password");
        waitAndGo(3000, "#login");
    } catch (err) {
        setError("Could not reset your password");
    }
}

async function verifyEmail(hash) {
    let id = hash.substring(hash.lastIndexOf("/")+1, hash.length);
    try {
        let response = await axios.get(`/api/verifyEmail/${id}`);
        setMessage("Successfully verified your email address, please login now");
        waitAndGo(3000, "#login");
    } catch (err) {
        setError("Could not verify your email address");
    }
}

async function changePassword(formId, api) {
    let formData = new FormData(document.querySelector(`#${formId}`));
    let data = Object.fromEntries(formData.entries());
    data.email = API.email;
    try {
        let response = await axios.post(api, data, {headers: {"Content-Type": "application/json"}});
        setMessage("Successfully changed password");
    } catch (err) {
        setError(err.response.data.error);
    }
}

async function logout() {
    let data = {email: API.email};
    try {
        let response = await axios.post("/api/logout", data, {headers: {"Content-Type": "application/json"}});
        document.cookie = `fwbAuthCookie=`;
        API.email = "";
        window.location = "#login";
    } catch (err) {
        setError(err.response.data.error);
    }
}


function getCookie(cname) {
  let name = cname + "=";
  let decodedCookie = decodeURIComponent(document.cookie);
  let ca = decodedCookie.split(';');
  for(let i = 0; i <ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

export {authCheck, login, signup, verifyEmail, forgotPassword, resetPassword, changePassword, logout, renderLoginForm, renderChangePasswordForm};