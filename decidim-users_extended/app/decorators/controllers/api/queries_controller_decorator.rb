# frozen_string_literal: true

Decidim::Api::QueriesController.class_eval do
  def create
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    result = Decidim::Api::Schema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    logger.error e.message
    logger.error e.backtrace.join("\n")

    message = if Rails.env.development?
                { message: e.message, backtrace: e.backtrace }
              else
                { message: "Internal Server error" }
              end

    render json: { errors: [message], data: {} }, status: :internal_server_error
  end
end