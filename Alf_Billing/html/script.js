var WasBistDu = "source"
var society = null

$(function() {
    window.addEventListener('message', function(event) {
        society = event.data.society

        if (event.data.target == "source") {
            if (event.data.type == "enableui") {

                document.body.style.display = event.data.enable ? "block" : "none";

                document.getElementById("price").min = "1";
                document.getElementById("price").max = event.data.maxPrice;

                document.getElementById('title').value = ""
                document.getElementById('price').value = ""
                document.getElementById('content').value = ""

                document.getElementById("title").disabled = false;
                document.getElementById("price").disabled = false;
                document.getElementById("content").disabled = false;

                WasBistDu = "source"
            }

        } else if (event.data.target == "target") {
            if (event.data.type == "enableui") {

                document.body.style.display = event.data.enable ? "block" : "none";

                document.getElementById("price").min = "1";
                document.getElementById("price").max = event.data.maxPrice;

                document.getElementById('title').value = event.data.label
                document.getElementById('price').value = event.data.price
                document.getElementById('content').value = event.data.content

                document.getElementById("title").disabled = true;
                document.getElementById("price").disabled = true;
                document.getElementById("content").disabled = true;

                WasBistDu = "targetPlayer"
            }
        }
    });



    document.getElementById("submit").onclick = submit;
    function submit() {
        if (WasBistDu == "source") {
            $.post('http://Alf_Billing/submitSource', JSON.stringify({
                text: $("#content").val(),
                title: $("#title").val(),
                price: $("#price").val(),
                society: society
            }));
        } else if (WasBistDu == "targetPlayer") {
            $.post('http://Alf_Billing/submitTarget', JSON.stringify({
                text: $("#content").val(),
                title: $("#title").val(),
                price: $("#price").val(),
                society: society
            }));
        }  
    }

    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            $.post('http://Alf_Billing/escape', JSON.stringify({}));
        }
    };

    document.getElementById("cancel").onclick = cancel;
    function cancel() {
        $.post('http://Alf_Billing/cancel', JSON.stringify({}));
    }
});