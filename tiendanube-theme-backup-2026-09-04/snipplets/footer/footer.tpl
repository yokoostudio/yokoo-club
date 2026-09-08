{% set has_social_network = store.facebook or store.twitter or store.pinterest or store.instagram or store.tiktok or store.youtube %}
{% set has_footer_contact_info = (store.whatsapp or store.phone or store.email or store.address or store.blog) and settings.footer_contact_show %}          

{% set has_footer_logo = "footer_logo.jpg" | has_custom_image %}
{% set has_footer_menu = settings.footer_menu and settings.footer_menu_show %}
{% set has_payment_logos = settings.payments %}
{% set has_shipping_logos = settings.shipping %}
{% set has_shipping_payment_logos = has_payment_logos or has_shipping_logos %}
{% set has_languages = languages | length > 1 and settings.languages_footer %}

{% set has_seal_logos = store.afip or ebit or settings.custom_seal_code or ("seal_img.jpg" | has_custom_image) %}
{% set show_help = not has_products and not has_social_network %}

{{ component('nubesdk-slot', { type: "before_footer" }) }}

<footer class="js-footer js-hide-footer-while-scrolling display-when-content-ready overflow-none {% if settings.footer_colors %}footer-colors{% endif %}" data-store="footer">
	<div class="container text-center">
		{% if has_footer_logo and template != 'password' %}
			<div class="mb-4 pb-2">
				<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ 'footer_logo.jpg' | static_url('large') }}" alt="{{ store.name }}" title="{{ store.name }}" class="footer-logo-img lazyload">
			</div>
		{% endif %}
		{% if has_social_network %}
			<div class="mb-4">
				{% include "snipplets/social/social-links.tpl" %}
			</div>
		{% endif %}

		{% if template != 'password' %}

			{# Foot Nav #}
			{% if has_footer_menu %}
				<div class="mb-3">
					{% include "snipplets/navigation/navigation-foot.tpl" %}
				</div>
			{% endif %}

			{% if settings.news_show %}
				<div class="mb-4">
					{% include 'snipplets/newsletter.tpl' %}
				</div>
			{% endif %}
		{% endif %}

		{# Contact info #}
		{% if has_footer_contact_info %}
			<div class="mb-3">
				{% include "snipplets/contact-links.tpl" with {footer: true} %}
			</div>
		{% endif %}

		{% if template != 'password' %}

			{# Logos Payments and Shipping #}
			{% if has_shipping_payment_logos or has_languages %}
				<div class="mb-4">

					{% if has_payment_logos %}
						<div class="footer-payments-shipping-logos d-inline-block align-middle">
							{{ component('payment-shipping-logos', {'type' : 'payments'}) }}
						</div>
					{% endif %}

					{% if has_shipping_logos %}
						<div class="footer-payments-shipping-logos d-inline-block align-middle">
							{{ component('payment-shipping-logos', {'type' : 'shipping'}) }}
						</div>
					{% endif %}

				</div>
			{% endif %}

			{# Language selector #}
			{% if has_languages %}
				<a href="#" data-toggle="#languages" class="js-modal-open btn-link font-small">{{ "Idiomas y monedas" | translate }}</a>
				{% embed "snipplets/modal.tpl" with{modal_id: 'languages', modal_class: 'bottom modal-centered-small', modal_position: 'center', modal_transition: 'slide', modal_header_title: true, modal_footer: false, modal_width: 'centered', modal_zindex_top: true} %}
					{% block modal_head %}
						{{ 'Idiomas y monedas' | translate }}
					{% endblock %}
					{% block modal_body %}
						{% include "snipplets/navigation/navigation-lang.tpl" %}
					{% endblock %}
				{% endembed %}
			{% endif %}

			{# AFIP - EBIT - Custom Seal #}
			{% if has_seal_logos %}
				<div class="row text-center">
					<div class="col p-3">
						{% if store.afip or ebit %}
							{% if store.afip %}
								<div class="footer-logo afip seal-afip">
									{{ store.afip | raw }}
								</div>
							{% endif %}
							{% if ebit %}
								<div class="footer-logo ebit seal-ebit">
									{{ ebit }}
								</div>
							{% endif %}
						{% endif %}
						{% if "seal_img.jpg" | has_custom_image or settings.custom_seal_code %}
							{% if "seal_img.jpg" | has_custom_image %}
								<div class="footer-logo custom-seal">
									{% if settings.seal_url != '' %}
										<a href="{{ settings.seal_url | setting_url }}" target="_blank">
									{% endif %}
										<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ "seal_img.jpg" | static_url }}" class="custom-seal-img lazyload" alt="{{ 'Sello de' | translate }} {{ store.name }}"/>
									{% if settings.seal_url != '' %}
										</a>
									{% endif %}
								</div>
							{% endif %}
							{% if settings.custom_seal_code %}
								<div class="custom-seal custom-seal-code">
									{{ settings.custom_seal_code | raw }}
								</div>
							{% endif %}
						{% endif %}

						{{ component('nubesdk-slot', { type: "footer_seals" }) }}

					</div>
				</div>
			{% endif %}
		{% endif %}

		{{ component('nubesdk-slot', { type: "inside_footer" }) }}

		<div class="my-2">
			{#
			La leyenda que aparece debajo de esta linea de código debe mantenerse
			con las mismas palabras y con su apropiado link a Tienda Nube;
			como especifican nuestros términos de uso: http://www.tiendanube.com/terminos-de-uso .
			Si quieres puedes modificar el estilo y posición de la leyenda para que se adapte a
			tu sitio. Pero debe mantenerse visible para los visitantes y con el link funcional.
			Os créditos que aparece debaixo da linha de código deverá ser mantida com as mesmas
			palavras e com seu link para Nuvem Shop; como especificam nossos Termos de Uso:
			http://www.nuvemshop.com.br/termos-de-uso. Se você quiser poderá alterar o estilo
			e a posição dos créditos para que ele se adque ao seu site. Porém você precisa
			manter visivél e com um link funcionando.
			#}
			{{ new_powered_by_link }}
		</div>
		<div class="d-inline-block mr-md-2 font-smallest">
			{{ "Copyright {1} - {2}. Todos los derechos reservados." | translate( (store.business_name ? store.business_name : store.name) ~ (store.business_id ? ' - ' ~ store.business_id : ''), "now" | date('Y') ) }}
		</div>
		{{ component('claim-info', {
				container_classes: "d-md-inline-block mt-md-0 mt-3 font-smallest",
				divider_classes: "mx-1 d-none d-md-inline-block",
				text_classes: {text_consumer_defense: 'd-inline-block mb-2'},
				link_classes: {
					link_consumer_defense: "btn-link font-smallest",
					link_order_cancellation: "btn-link font-smallest d-md-inline-block d-block mb-2 w-100 w-md-auto",
				},
			}) 
		}}
	</div>
</footer>

{{ component('nubesdk-slot', { type: "after_footer" }) }}