{% embed "snipplets/page-header.tpl" %}
	{% block page_header_text %}{{ 'Crear cuenta' | translate }}{% endblock page_header_text %}
{% endembed %}

<section class="account-page mb-4">
	<div class="container">
		<div class="row justify-content-center">
			<div class="col-md-6">

				{{ component('nubesdk-slot', { type: "before_register_form" }) }}

				<h2 class="h6 font-body font-weight-normal mb-4 text-center">{{ 'Comprá más rápido y llevá el control de tus pedidos, ¡en un solo lugar!'| translate }}</h2>

				{{ component('forms/account/register' , {
					validation_classes: {
						link: 'btn-link font-small ml-1',
						text_align: 'text-center',
						text_size: 'font-small',
					},
					spacing_classes: {
						top_2x: 'mt-2',
						bottom_2x: 'mb-2',
						bottom_3x: 'mb-3',
					},
					form_classes: {
						facebook_login: 'btn btn-secondary d-block mb-4',
						password_toggle: 'btn',
						input_help_align: 'text-right',
						input_help_link: 'btn-link btn-link font-small mb-2 mr-1',
						help_align: 'text-center',
						help_text_size: 'font-small',
						help_link: 'btn-link btn-link font-small mb-2 ml-1',
						submit: 'btn btn-primary btn-big btn-block',
						submit_spinner: 'icon-inline icon-spin ml-2',
						input_error: 'notification-left',
					}})
				}}

				{{ component('nubesdk-slot', { type: "after_register_form" }) }}

			</div>
		</div>
	</div>
</section>
