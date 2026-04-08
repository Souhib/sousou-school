// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
	site: 'https://school.majlisna.app',
	integrations: [
		starlight({
			title: 'Sousou School',
			description: 'Formation DevOps — De zéro à prêt pour l\'entretien',
			defaultLocale: 'root',
			locales: {
				root: { label: 'Français', lang: 'fr' },
				en: { label: 'English', lang: 'en' },
			},
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/Souhib/devops-from-zero',
				},
				{
					icon: 'linkedin',
					label: 'LinkedIn',
					href: 'https://www.linkedin.com/in/souhib-trabelsi/',
				},
			],
			customCss: ['./src/styles/custom.css'],
			head: [
				{
					tag: 'link',
					attrs: {
						rel: 'preconnect',
						href: 'https://fonts.googleapis.com',
					},
				},
				{
					tag: 'link',
					attrs: {
						rel: 'preconnect',
						href: 'https://fonts.gstatic.com',
						crossorigin: true,
					},
				},
				{
					tag: 'link',
					attrs: {
						rel: 'stylesheet',
						href: 'https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap',
					},
				},
			],
			sidebar: [
				{
					label: 'Modules',
					items: [
						{ slug: 'modules/00-prerequisites', label: '0. Prérequis' },
						{ slug: 'modules/01-linux-basics', label: '1. Linux' },
						{ slug: 'modules/02-networking', label: '2. Réseau' },
						{ slug: 'modules/03-docker', label: '3. Docker' },
						{ slug: 'modules/04-cicd', label: '4. CI/CD' },
						{ slug: 'modules/05-aws', label: '5. AWS' },
						{ slug: 'modules/06-terraform', label: '6. Terraform' },
						{ slug: 'modules/07-ansible', label: '7. Ansible (optionnel)' },
						{ slug: 'modules/08-monitoring', label: '8. Monitoring' },
						{ slug: 'modules/09-kubernetes', label: '9. Kubernetes (optionnel)' },
					],
				},
				{
					label: 'Entretien',
					items: [
						{ slug: 'entretien/interview-questions', label: 'Questions d\'entretien' },
						{ slug: 'entretien/interview-experience', label: 'Questions d\'expérience' },
						{ slug: 'entretien/system-design', label: 'System Design' },
					],
				},
				{
					label: 'Références',
					items: [
						{ slug: 'references/cheatsheet', label: 'Cheatsheet' },
						{ slug: 'references/troubleshooting', label: 'Troubleshooting' },
						{ slug: 'references/aller-plus-loin', label: 'Aller plus loin' },
					],
				},
				{
					label: 'Projet',
					items: [
						{ slug: 'projet', label: 'Projet fil rouge' },
					],
				},
			],
			lastUpdated: true,
			pagination: true,
		}),
	],
});
