{% if settings.welcome_message or settings.welcome_text %}
	<section class="section-welcome-home" data-store="home-welcome-message">
		<div class="container">
			<div class="row text-center justify-content-center">
				<div class="col-md-8">
					<p class="js-welcome-message-title mb-3" {% if not settings.welcome_message %}style="display: none"{% endif %}>{{ settings.welcome_message }}</p>
					<h2 class="js-welcome-message-text mb-4{% if settings.welcome_italic %} font-italic{% endif %}" {% if not settings.welcome_text %}style="display: none"{% endif %}>{{ settings.welcome_text }}</h2>
					<a href="{{ settings.welcome_link }}" class="js-welcome-message-button btn-link" data-has-url="{{ settings.welcome_link ? 'true' : 'false' }}" {% if not (settings.welcome_button and settings.welcome_link) %}style="display: none"{% endif %}>{{ settings.welcome_button }}</a>
				</div>
			</div>
		</div>
	</section>
{% endif %}
