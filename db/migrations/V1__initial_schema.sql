CREATE TABLE role (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(45),
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `user` (
    id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(255),
    userEmail VARCHAR(255),
    profileImg VARCHAR(255),
    profileImgPath VARCHAR(255),
    dateOfBirth VARCHAR(255),
    fatherName VARCHAR(255),
    motherName VARCHAR(255),
    gender VARCHAR(255),
    maritalStatus VARCHAR(255),
    permanentAddress VARCHAR(255),
    tempAddress VARCHAR(255),
    primaryOccupation VARCHAR(255),
    secondaryOccupation VARCHAR(255),
    skills VARCHAR(255),
    phoneNumber VARCHAR(255),
    secondaryPhoneNumber VARCHAR(255),
    nationality VARCHAR(255),
    language VARCHAR(255),
    workingExperience VARCHAR(255),
    password VARCHAR(255),
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_role (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_role_roleid
        FOREIGN KEY (role_id) REFERENCES role(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_role_userid
        FOREIGN KEY (user_id) REFERENCES `user`(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO role (id, name) VALUES
(1, 'ROLE_USER'),
(2, 'ROLE_ADMIN');
