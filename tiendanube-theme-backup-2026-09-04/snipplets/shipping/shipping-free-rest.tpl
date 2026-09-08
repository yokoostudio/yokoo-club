{% if product_detail %}
	
	{% if not product.free_shipping %}
		
		{# Wording to notice that adding one more product free shipping is achieved #}

		<div class="js-shipping-add-product-label font-small mx-3 my-3">
			<span class='js-fs-add-this-product'>{{ "¡Agregá este producto y " | translate }}</span>
			<span class='js-fs-add-one-more' style='display: none;'>{{ "¡Agregá uno más y " | translate }}</span>
			<span class='text-accent'>{{ "tenés envío gratis!" | translate }}</span>
		</div>
	{% endif %}

{% else %}
	{{ component('free-shipping-bar', {
		progress_bar_classes: {
			container: 'js-ship-free-rest progress-bar mt-2 mb-5 pb-1',
			title_container: 'progress-bar-title-container',
			title: 'js-ship-free-rest-message ship-free-rest-message progress-bar-title text-accent',
			track: 'bar-progress',
			fill: 'bar-progress-active transition-soft',
			check: 'bar-progress-check transition-soft',
			check_icon: 'icon-inline',
		},
		check_svg_id: 'check',
		show_check: true,
	}) }}
{% endif %}
