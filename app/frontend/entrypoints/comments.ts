import $ from 'jquery';

$(() => {
    $('.edit-form,.reply-form,.comment-form').hide();
    $('.edit-button').on('click', function (e) {
        const button = $(this);
        button.hide();
        const commentId = button.data('id');
        $(`#comment-${commentId}-edit`).show();
        $(`#comment-${commentId}-body`).hide();
    });
    $('.reply-button').on('click', function (e) {
        const button = $(this);
        button.hide();
        const commentId = button.data('id');
        $(`.reply-form[data-id="${commentId}"`).show();
    });

    $('.cancel-reply').on('click', function (e) {
        const commentId = $(this).data('id');
        $(`.reply-form[data-id="${commentId}"`).hide();
        $(`.reply-button[data-id="${commentId}"`).show();
    });

    $('.cancel-edit').on('click', function (e) {
        const commentId = $(this).data('id');
        $(`#comment-${commentId}-edit`).hide();
        $(`#comment-${commentId}-body`).show();
        $(`.edit-button[data-id="${commentId}`).show();
    });
    $('.comment-button').on('click', function (e) {
        const button = $(this);
        button.hide();
        const commentId = button.data('id');
        $(`.comment-form[data-id="${commentId}"`).show();
    });
    $('.cancel-comment').on('click', function (e) {
        const commentId = $(this).data('id');
        $(`.comment-form[data-id="${commentId}"`).hide();
        $(`.comment-button[data-id="${commentId}"`).show();
    });
});
