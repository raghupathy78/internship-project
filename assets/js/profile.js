$("#saveProfile").click(function () {

    let token = localStorage.getItem("token");

    if (!token) {
        alert("Session expired. Please login again.");
        window.location.href = "login.html";
        return;
    }

    $.ajax({
        url: "php/profile.php",
        type: "POST",
        data: {
            token: token,
            age: $("#age").val(),
            dob: $("#dob").val(),
            contact: $("#contact").val()
        },
        success: function (response) {
            let res = JSON.parse(response);

            if (res.status === "unauthorized") {
                alert("Session expired. Please login again.");
                localStorage.removeItem("token");
                window.location.href = "login.html";
            } else {
                alert("Profile saved successfully");
            }
        }
    });
});
