$(function () {
    $('.edit-form,.reply-form,.comment-form').hide();
    $('.edit-button').click(function (e) {
        const button = $(this);
        button.hide();
        const commentId = button.data('id');
        $(`#comment-${commentId}-edit`).show();
        $(`#comment-${commentId}-body`).hide();
    });
    $('.reply-button').click(function (e) {
        const button = $(this);
        button.hide();
        const commentId = button.data('id');
        $(`.reply-form[data-id="${commentId}"`).show();
    });

    $('.cancel-reply').click(function (e) {
        const commentId = $(this).data('id');
        $(`.reply-form[data-id="${commentId}"`).hide();
        $(`.reply-button[data-id="${commentId}"`).show();
    });

    $('.cancel-edit').click(function (e) {
        const commentId = $(this).data('id');
        $(`#comment-${commentId}-edit`).hide();
        $(`#comment-${commentId}-body`).show();
        $(`.edit-button[data-id="${commentId}`).show();
    });
    $('.comment-button').click(function (e) {
        const button = $(this);
        button.hide();
        const commentId = button.data('id');
        $(`.comment-form[data-id="${commentId}"`).show();
    });
    $('.cancel-comment').click(function (e) {
        const commentId = $(this).data('id');
        $(`.comment-form[data-id="${commentId}"`).hide();
        $(`.comment-button[data-id="${commentId}"`).show();
    });
});
