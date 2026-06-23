FROM public.ecr.aws/lambda/ruby:3.3 AS builder

RUN dnf install -y gcc gcc-c++ make && dnf clean all

COPY Gemfile ${LAMBDA_TASK_ROOT}/
WORKDIR ${LAMBDA_TASK_ROOT}
RUN bundle config set --local path vendor/bundle && \
    bundle config set without 'development test' && \
    bundle install --jobs 4

FROM public.ecr.aws/lambda/ruby:3.3

RUN dnf install -y ImageMagick && dnf clean all

COPY --from=builder ${LAMBDA_TASK_ROOT}/ ${LAMBDA_TASK_ROOT}/
COPY handler.rb ${LAMBDA_TASK_ROOT}/

ENV BUNDLE_PATH=${LAMBDA_TASK_ROOT}/vendor/bundle

CMD ["handler.lambda_handler"]
