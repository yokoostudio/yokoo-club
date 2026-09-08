{# Informative banners that work as examples #}

<section class="section-informative-banners" data-store="banner-services">
	<div class="container position-relative py-3">
		<div class="js-informative-banners-demo swiper-container mb-3">
			<div class="swiper-wrapper">
				{% include 'snipplets/defaults/help_banner_services_item.tpl' with {'help_item_1': true} %}
				{% include 'snipplets/defaults/help_banner_services_item.tpl' with {'help_item_2': true} %}
				{% include 'snipplets/defaults/help_banner_services_item.tpl' with {'help_item_3': true} %}
				{% include 'snipplets/defaults/help_banner_services_item.tpl' with {'help_item_4': true} %}
			</div>
		</div>
		<div class="text-center mt-4 d-block d-md-none">
			<div class="js-informative-banners-prev-demo swiper-button-prev">
				<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
			</div>
			<div class="js-informative-banners-next-demo swiper-button-next">
				<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
			</div>
		</div>
		<div class="placeholder-overlay transition-soft">
			<div class="placeholder-info p-2">
				<svg class="icon-inline icon-2x"><use xlink:href="#edit"/></svg>
				<div class="placeholder-description font-small-xs my-2">
					{{ "Podés mostrar tu información para la compra desde" | translate }} </br><strong>"{{ "Información de envíos, pagos y compra" | translate }}"</strong>
				</div>
				{% if not params.preview %}
					<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
				{% endif %}
			</div>
		</div>
	</div>
</section>