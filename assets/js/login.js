$("#loginBtn").click(function () {

    let email = $("#email").val();
    let password = $("#password").val();

    if (email === "" || password === "") {
        alert("Email and password required");
        return;
    }

    $.ajax({
        url: "php/login.php",
        type: "POST",
        data: {
            email: email,
            password: password
        },
        success: function (response) {
            console.log("Server Response:", response);
            let res = JSON.parse(response);

            if (res.status === "success") {
                localStorage.setItem("token", res.token);
                window.location.href = "profile.html";
            } else {
                alert("Login failed");
            }
        },
        error: function () {
            alert("An error occurred, please try again.");
        }
    });
});
