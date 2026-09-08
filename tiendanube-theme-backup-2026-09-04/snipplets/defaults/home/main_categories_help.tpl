{# Main categories that work as examples #}

<section class="section-categories-home position-relative" data-store="home-categories-featured">
	<div class="container position-relative">
		<h2 class="h3 mt-3 mb-4 text-center">{{ 'Categorías' | translate }}</h2>
		<div class="js-swiper-categories-demo swiper-container">
			<div class="swiper-wrapper">
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_1': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_2': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_3': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_1': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_2': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_3': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_1': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_2': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_3': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_1': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_2': true}  %}
				{% include 'snipplets/defaults/home/main_category_item_help.tpl' with {'help_item_3': true}  %}  
			</div>
		</div>
		<div class="text-center mt-4">
			<div class="js-swiper-categories-prev-demo swiper-button-prev svg-icon-text">
				<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
			</div>
			<div class="js-swiper-categories-next-demo swiper-button-next svg-icon-text">
				<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
			</div>
		</div>
		<div class="placeholder-overlay transition-soft">
			<div class="placeholder-info p-2">
				<svg class="icon-inline icon-2x"><use xlink:href="#edit"/></svg>
				<div class="placeholder-description font-small-xs my-2">
					{{ "Podés mostrar tus categorías principales desde" | translate }} </br><strong>"{{ "Categorías principales" | translate }}"</strong>
				</div>
				{% if not params.preview %}
					<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
				{% endif %}
			</div>
		</div>
	</div>
</section>
