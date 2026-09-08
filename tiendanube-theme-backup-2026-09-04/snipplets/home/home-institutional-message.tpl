{% if settings.institutional_message or settings.institutional_text %}
	<section class="section-institutional-home" data-store="home-institutional-message">
		<div class="container">
			<div class="row text-center justify-content-center">
				<div class="col-md-8">
					<p class="js-institutional-message-title mb-3" {% if not settings.institutional_message %}style="display: none"{% endif %}>{{ settings.institutional_message }}</p>
					<h2 class="js-institutional-message-text mb-4{% if settings.institutional_italic %} font-italic{% endif %}" {% if not settings.institutional_text %}style="display: none"{% endif %}>{{ settings.institutional_text }}</h2>
					<a href="{{ settings.institutional_link }}" class="js-institutional-message-button btn-link" data-has-url="{{ settings.institutional_link ? 'true' : 'false' }}" {% if not (settings.institutional_button and settings.institutional_link) %}style="display: none"{% endif %}>{{ settings.institutional_button }}</a>
				</div>
			</div>
		</div>
	</section>
{% endif %}
