<div class="swiper-slide col-auto col-md p-0">
	<div class="text-center">
		<div class="d-inline-block icon-60px mb-3">
			{% set help_icon_name = help_item_1 ? 'box-alt' : help_item_2 ? 'credit-card-alt' : help_item_3 ? 'promotions' : 'returns' %}
			<svg class="icon-inline icon-4x align-item-middle svg-icon-text"><use xlink:href="#{{ help_icon_name }}"/></svg>
		</div>
		<h3 class="mb-2">
			{% if help_item_1 %}
        		{{ 'Medios de envío' | translate }}
        	{% elseif help_item_2 %}
        		{{ 'Medios de pago' | translate }}
        	{% elseif help_item_3 %}
        		{{ 'Promociones' | translate }}
        	{% elseif help_item_4 %}
        		{{ 'Cambios y devoluciones' | translate }}
        	{% endif %}
		</h3>
	</div>
</div>