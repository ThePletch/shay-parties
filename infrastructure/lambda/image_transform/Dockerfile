FROM public.ecr.aws/lambda/ruby:3.3

RUN dnf install -y ImageMagick && dnf clean all

COPY Gemfile ${LAMBDA_TASK_ROOT}/
RUN bundle config set without 'development test' && \
    bundle install --jobs 4

COPY handler.rb ${LAMBDA_TASK_ROOT}/

CMD ["handler.lambda_handler"]
