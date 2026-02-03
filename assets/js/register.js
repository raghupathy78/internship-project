$("#registerBtn").click(function () {

    let name = $("#name").val();
    let email = $("#email").val();
    let password = $("#password").val();

    if (name === "" || email === "" || password === "") {
        alert("All fields are required");
        return;
    }

    $.ajax({
        url: "php/register.php",
        type: "POST",
        data: {
            name: name,
            email: email,
            password: password
        },
        success: function (response) {
            let res = JSON.parse(response);
            alert(res.msg);

            if (res.status === "success") {
                window.location.href = "login.html";
            }
        }
    });
});
