{# Slider that work as example #}

{% set slide_view_box = '0 0 1440 770' %}

<div class="js-home-slider-placeholder">
	<div class="section-slider p-0">
		<div class="container">
			<div class="js-home-empty-slider swiper-container">
				<div class="swiper-wrapper">
					<div class="swiper-slide slide-container">
						<svg viewBox='{{ slide_view_box }}'><use xlink:href="#slider-slide-placeholder"/></svg>
					</div>
					<div class="swiper-slide slide-container">
						<svg viewBox='{{ slide_view_box }}'><use xlink:href="#slider-slide-placeholder"/></svg>
					</div>
					<div class="swiper-slide slide-container">
						<svg viewBox='{{ slide_view_box }}'><use xlink:href="#slider-slide-placeholder"/></svg>
					</div>
				</div>
				<div class="placeholder-overlay placeholder-slider transition-soft">
					<div class="placeholder-info">
						<svg class="icon-inline icon-3x"><use xlink:href="#edit"/></svg>
						<div class="placeholder-description font-small-xs">
							{{ "Podés subir imágenes principales desde" | translate }} <strong>"{{ "Carrusel de imágenes" | translate }}"</strong>
						</div>
						{% if not params.preview %}
							<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
						{% endif %}
					</div>
				</div>
				<div class="mt-2 text-center">
					<div class="js-swiper-empty-home-prev swiper-button-prev">
						<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
					</div>
					<div class="js-swiper-empty-home-pagination swiper-pagination-fraction"></div>
					<div class="js-swiper-empty-home-next swiper-button-next">
						<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

{# Skeleton of "true" section accessed from instatheme.js #}
<div class="js-home-slider-top" style="display:none">
	{% include 'snipplets/home/home-slider.tpl' %}
	{% if has_mobile_slider %}
		{% include 'snipplets/home/home-slider.tpl' with {mobile: true} %}
	{% endif %}
</div>