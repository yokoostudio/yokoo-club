{% set notification_without_recommendations_classes = 'js-alert-added-to-cart notification-floating notification-cart-container notification-hidden notification-fixed position-absolute' %}
{% set notification_wrapper_classes = 
	related_products ? 'row' 
	: not related_products and not settings.head_fix_desktop ? notification_without_recommendations_classes ~ ' position-fixed-md' 
	: notification_without_recommendations_classes 
%}

<div class="{{ notification_wrapper_classes }}" {% if not related_products %}style="display: none;"{% endif %}>
	<div class="{% if related_products %}col-12 col-md mb-3 mb-md-0{% else %}notification notification-primary notification-cart{% endif %}">
		{% if not related_products %}
			<div class="js-cart-notification-close notification-close mt-2 mr-1">
				<svg class="icon-inline icon-lg notification-icon"><use xlink:href="#times"/></svg>
			</div>
		{% endif %}
		<div class="js-cart-notification-item row no-gutters" data-store="cart-notification-item">
			<div class="col-auto pr-0 notification-img notification-img-big">
				<img src="" class="js-cart-notification-item-img absolute-centered-vertically" />
			</div>
			<div class="col text-left py-2 pl-3">
				<div class="mb-1 mr-4">
					<span class="js-cart-notification-item-name"></span>
					<span class="js-cart-notification-item-variant-container" style="display: none;">
						(<span class="js-cart-notification-item-variant"></span>)
					</span>
				</div>
			<div class="d-flex align-items-center mt-2 mb-2">
				<span class="js-cart-notification-item-quantity"></span>
				<span> x </span>
				<span class="js-cart-notification-item-price"></span>
				<span class="js-cart-notification-discount-label ml-2" style="display: none;">
					<span class="label label-accent label-small px-2 py-1"><strong class="js-cart-notification-discount-percentage"></strong></span>
				</span>
			</div>
				{% if not related_products %}
					<strong>{{ '¡Agregado al carrito!' | translate }}</strong>
				{% endif %}
			</div>
		</div>
	</div>
	{% if related_products %}
		<div class="col-12 col-md-auto">
			<div class="mb-3">
				<div class="row text-primary h4 mb-3">
					<span class="col-auto text-left">
						<strong>{{ "Total" | translate }}</strong> 
						(<span class="js-cart-widget-amount">
							{{ "{1}" | translate(cart.items_count ) }} 
						</span>
						<span class="js-cart-counts-plural" style="display: none;">
							{{ 'productos' | translate }}):
						</span>
						<span class="js-cart-counts-singular" style="display: none;">
							{{ 'producto' | translate }}):
						</span>
					</span>
					<strong class="js-cart-total col text-right">{{ cart.total | money }}</strong>
				</div>
			</div>
			<a href="#" data-toggle="#modal-cart" data-modal-url="modal-fullscreen-cart" class="js-modal-close js-modal-open js-fullscreen-modal-open btn btn-primary btn-big d-block">{{ 'Ver carrito' | translate }}</a>
		</div>
	{% endif %}
</div>

