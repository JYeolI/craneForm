<%--
  Created by IntelliJ IDEA.
  User: Admin
  Date: 2023-03-11
  Time: 오후 9:31
  To change this template use File | Settings | File Templates.
--%>

<%--
    TODO selectAllOption에 맞춰서 수정할 필요 유
--%>

<%@ include file="../header.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>

    .detail_main {
        background-color: #f3f3f3;
        margin: auto;
    }

    .shadow-detail {
        box-shadow: 0 0.5rem 1.5rem rgba(0, 0, 0, .275) !important
    }

    .question_main {
        margin-left: 3%;
        text-align: left;
        padding: 2%;
    }

    .question_detail {
        font-weight: bolder;
    }

    .option_main {
        margin-top: 2%;
        color: #464646;
        font-weight: bold;
    }

    .option_main input {
        margin-right: 2px;
    }

    .option_main label {
        margin-right: 3%;
    }

    .badge-primary {
        background-color: #b44cd0;
        color: white;
        padding: 3px 5px;
        border-radius: 3px;
        margin-left: 5px;
    }

    .badge-warning {
        background-color: #d5af14;
        color: white;
        padding: 3px 5px;
        border-radius: 3px;
        margin-left: 5px;
    }

    .badge-danger {
        background-color: #d5564a;
        color: white;
        padding: 3px 5px;
        border-radius: 3px;
        margin-left: 5px;
    }

    .badge-gray {
        background-color: #b8b8b8;
        color: white;
        padding: 3px 5px;
        border-radius: 3px;
        margin-left: 5px;
    }

</style>

<div class="container" style="padding-top: 2%; display: flex; justify-content : center;">
    <fmt:formatDate var="si_created_date" value="${surveyInfo.si_created_date}"
                    pattern="yyyy-MM-dd (E) "/> <%-- 날짜 형식 지정 --%>
    <div class="col-2"></div>
    <div class="col-10">
        <form method="post" id="answerForm">
            <input type="hidden" name="si_no" value="${surveyInfo.si_no}">
            <div class="card shadow-detail text-center detail_main shadow">
                <h1 class="mt-5">${surveyInfo.si_subtitle}</h1>
                <h5 class="mt-1" style="color: #8f8f8f">${surveyInfo.si_detail}</h5>
                <span class="mt-3" style="text-align: right; margin-right: 3%">${si_created_date}</span>
                <hr>

                <c:forEach var="qo" items="${questionAndOption}" varStatus="vs">
                    <div class="question_main mt-2 mb-3">
                    <span class="question_detail">${qo.qs_order + 1}. ${qo.qs_detail}
                    <c:if test="${qo.qs_required eq 'on'}"><span
                            style="color: red; font-weight: bold">* (필수)</span></c:if>
                    <c:if test="${qo.qs_type eq '객관식'}"><span class="badge badge-primary">객관식</span></c:if>
                    <c:if test="${qo.qs_type eq '체크박스'}"><span class="badge badge-warning">체크박스</span></c:if>
                    <c:if test="${qo.qs_type eq '셀렉트박스'}"><span class="badge badge-danger">셀렉트박스</span></c:if>
                    <c:if test="${qo.qs_type eq '주관식 - 단답형'}"><span class="badge badge-gray">주관식 - 단답형</span></c:if>
                    </span>
                        <div class="option_main">
                            <input type="hidden" name="answer_type_${qo.qs_order}" value="${qo.qs_type}">
                            <c:choose>
                                <c:when test="${qo.qs_type eq '셀렉트박스'}">
                                    <select id="option_${qo.qs_no}" name="answer_${qo.qs_no}">
                                        <c:forEach var="so" items="${qo.selectOptionList}" varStatus="vs2">
                                            <option value="${so.so_no}"
                                                    <c:if test="${vs2.index == 0}">selected</c:if>>${so.so_detail}</option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="so" items="${qo.selectOptionList}" varStatus="vs2">
                                        <c:choose>
                                            <c:when test="${qo.qs_type eq '객관식'}">
                                                <input type="radio" id="option_${so.so_qs_no}_${so.so_no}"
                                                       name="answer_${qo.qs_no}"
                                                       value="${so.so_no}"
                                                       <c:if test="${qo.qs_required eq 'on'}">required</c:if>>
                                                <label for="option_${so.so_qs_no}_${so.so_no}">${so.so_detail}</label>
                                            </c:when>
                                            <c:when test="${qo.qs_type eq '체크박스'}">
                                                <input type="checkbox" id="option_${so.so_qs_no}_${so.so_no}"
                                                       name="answer_${qo.qs_no}_${so.so_no}">
                                                <label for="option_${so.so_qs_no}_${so.so_no}">${so.so_detail}</label>
                                            </c:when>
                                            <c:when test="${qo.qs_type eq '주관식 - 단답형'}">
                                                <input type="text" id="option_${so.so_qs_no}_${so.so_no}"
                                                       name="answer_${qo.qs_no}_${so.so_no}">
                                            </c:when>
                                        </c:choose>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div style="text-align: center">
                <button type="button" class="btn btn-lg btn-outline-primary mt-5"
                        style="width: 80%" onclick="submitAnswer()">제출
                </button>
                <button type="reset" class="btn btn-outline-gray-500 mt-5">초기화</button>
            </div>
        </form>
    </div>
    <div class="col-2"></div>
</div>

<script>

    // 답변 제출
    function submitAnswer() {

        let form_data = $('form').serialize();
        let json_data = JSON.stringify({form_data: form_data}); // 객체를 json 타입으로 변경 (직렬화)
        let form = document.getElementById('answerForm');

        // 유효성 검사를 해주는 함수
        if (form.checkValidity()) {
            $.ajax({
                type: "POST",
                url: "/api/submitAnswer",
                contentType: "application/json",
                data: json_data,
                success: function (result) {
                    alert('제출 성공');
                    location.href = "/";
                },
                error: function (error) {
                    console.log('error : ' + error)
                }
            })
        } else {
            form.reportValidity();
        }

    }

</script>

<%@ include file="../footer.jsp" %>
