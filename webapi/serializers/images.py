import hashlib
import os.path
import random
import string
import tempfile
import uuid
from pathlib import Path

import boto3
from django.utils.functional import cached_property
from rest_framework import serializers


class ReadImageSerializer(serializers.Serializer):

    image_id = serializers.CharField()

    class Meta:
        fields = ("image_id",)


class WriteImageSerializer(serializers.Serializer):

    image = serializers.FileField()

    class Meta:
        fields = ("image",)

    @cached_property
    def s3_bucket(self):
        session = boto3.Session(profile_name=os.getenv("AWS_PROFILE"))
        resource = session.resource("s3", endpoint_url=os.getenv("AWS_S3_ENDPOINT_URL"))
        bucket = resource.Bucket("training-store")
        return bucket

    @cached_property
    def letters(self):
        return f"{string.digits}{string.ascii_letters}"

    def create(self, validated_data):
        image = validated_data.pop("image")
        real_filename = image.name
        char = "".join([random.choice(self.letters) for _ in range(random.randint(30, 50))])
        name = hashlib.shake_256(f"{real_filename}{char}".encode()).hexdigest(20)
        extension = os.path.splitext(real_filename)[::-1][0]
        filename = f"{name}{extension}"
        with tempfile.TemporaryDirectory() as tmpdir:
            with open(Path(tmpdir) / filename, "wb") as destination:
                for chunk in image:
                    destination.write(chunk)

            upload_path = f"images/{str(uuid.uuid4()).replace('-', '/')}/{filename}"

            self.s3_bucket.upload_file(
                str(Path(tmpdir) / filename), upload_path, ExtraArgs={"ContentType": image.content_type}
            )

        return {"image_id": f"training-store/{upload_path}"}
