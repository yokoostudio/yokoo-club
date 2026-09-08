{% set newsletter_contact_error = contact.type == 'newsletter' and not contact.success %}
{% set has_newsletter_full = settings.home_news_full %}
{% set newsletter_image = "home_news_image.jpg" | has_custom_image %}
{% set theme_editor = params.preview %}
<section class="position-relative overflow-none" data-store="home-newsletter">

    {{ component('nubesdk-slot', { type: 'before_section_newsletter' }) }}

	<div class="js-newsletter-home-container container{% if has_newsletter_full %}-fluid p-0{% else %} my-3{% endif %}">
		<div class="js-newsletter-home row no-gutters section-newsletter-home {% if settings.home_news_colors %}section-newsletter-home-colors{% endif %} align-items-center justify-content-center text-center">
			<div class="col-md-6">
				<div class="js-newsletter newsletter px-4 py-5">
					
					<h2 class="js-home-newsletter-title h4 mb-2" {% if not settings.home_news_title %}style="display: none;"{% endif %}>{{ settings.home_news_title }}</h2>
					<p class="js-home-newsletter-text font-small mb-2" {% if not settings.home_news_text %}style="display: none;"{% endif %}>{{ settings.home_news_text }}</p>

					<form class="mt-3 mb-2" method="post" action="/winnie-pooh" onsubmit="this.setAttribute('action', '');" data-store="home-newsletter-form">
						<div class="input-append">
							{% embed "snipplets/forms/form-input.tpl" with{input_for: 'email', type_email: true, input_name: 'email', input_id: 'email', input_placeholder: 'Email' | translate, input_group_custom_class: "mb-0",  input_aria_label: 'Email' | translate } %}
							{% endembed %}
							<div class="winnie-pooh" style="display: none;">
								<label for="winnie-pooh-newsletter">{{ "No completar este campo" | translate }}</label>
								<input id="winnie-pooh-newsletter" type="text" name="winnie-pooh"/>
							</div>
							<input type="hidden" name="name" value="{{ 'Sin nombre' | translate }}" />
							<input type="hidden" name="message" value="{{ 'Pedido de inscripción a newsletter' | translate }}" />
							<input type="hidden" name="type" value="newsletter" />
							<input type="submit" name="contact" class="btn btn-link font-small newsletter-btn" value="{{ 'Enviar' | translate }}" />
						</div>
					</form>

					{% if contact and contact.type == 'newsletter' %}
						{% if contact.success %}
							<div class="alert alert-success">{{ "¡Gracias por suscribirte! A partir de ahora vas a recibir nuestras novedades en tu email" | translate }}</div>
						{% else %}
							<div class="alert alert-danger">{{ "Necesitamos tu email para enviarte nuestras novedades." | translate }}</div>
						{% endif %}
					{% endif %}

				</div>
			</div>
			{% if newsletter_image or theme_editor %}
				<div class="js-home-newsletter-image-container col-md-6 order-first order-md-last" {% if not newsletter_image %}style="display: none;"{% endif %}>
					<img {% if newsletter_image %}src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "home_news_image.jpg" | static_url | settings_image_url('large') }} 480w, {{ "home_news_image.jpg" | static_url | settings_image_url('huge') }} 640w, {{ "home_news_image.jpg" | static_url | settings_image_url('original') }} 1024w, {{ "home_news_image.jpg" | static_url | settings_image_url('1080p') }} 1920w'{% endif %} class='js-home-newsletter-image lazyload fade-in d-block w-100'/>
					<div class="placeholder-fade"></div>
				</div>
			{% endif %}
		</div>
	</div>

    {{ component('nubesdk-slot', { type: 'after_section_newsletter' }) }}

</section>
